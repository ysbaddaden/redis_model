module RedisModel
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      def count
        connection.scard(index_key(:id))
      end

      def hkey(attr_name)
        key("*->#{attr_name}")
      end

      def exists?(id)
        connection.exists(key(id))
      end

      # Finds records.
      # 
      # Examples:
      # 
      #   posts = Post.find :all
      #   posts = Post.find :all, :offset => 20, :limit => 10
      # 
      # The following calls are equivalent, and will return the same record:
      # 
      #   post = Post.find :first, :by => :position, :order => :desc
      #   post = Post.find :last,  :by => :position, :order => :asc
      # 
      # Finds all comments for a given post:
      # 
      #   comments = Comment.find :all, :index => [ :post_id, 123 ], :by => :approved_at
      # 
      # Options:
      # 
      # - <tt>:index</tt>  - either an indexed attribute name, or an array of [ attr_name, value ] (defaults to <tt>:id</tt>).
      # - <tt>:by</tt>     - an attribute name to sort by or <tt>:nosort</tt> to not sort result (defaults to <tt>:nosort</tt>).
      # - <tt>:order</tt>  - either <tt>:asc</tt>, <tt>:desc</tt> or <tt>:alpha</tt> or an array of <tt>:asc</tt> or <tt>:desc</tt> with <tt>:alpha</tt>.
      # - <tt>:limit</tt>  - an array of [ offset, limit ]
      # - <tt>:select</tt> - an array of attribute names to get (defaults to all attributes)
      # 
      def find(*args)
        if args.first.is_a?(Symbol)
          options = args.extract_options!
          limit, by, order, index = parse_find_options(options)

          case args.first
          when :all
            # pass
          when :first
#            return find_with_range(index, 0, 0) if by.nil? && order.blank?
            limit = [ 0, 1 ]
          when :last
#            return find_with_range(index, -1, -1) if by.nil? && order.blank?
            limit = [ 0, 1 ]
            if order.include?(:asc)
              order.delete(:asc)
              order << :desc
            else
              order.delete(:desc)
              order << :asc
            end
          else
            raise RedisModelError.new("unknown find method #{args.first.inspect}")
          end

          fields = (options[:select] || attribute_names).sort
          results = connection.sort(index_key(*index),
            :get   => fields.collect { |k| hkey(k) },
            :by    => hkey(by),
            :order => order.join(" ").upcase,
            :limit => limit
          )
          collection = []

          # redis-rb < 3.0.0
          #results.each_slice(fields.size) do |values|
          #  collection << instanciate(Hash[ *fields.zip(values).flatten ])
          #end

          # redis-rb > 3.0.0
          results.each do |values|
            collection << instanciate(Hash[ *fields.zip(values).flatten ])
          end

          case args.first
          when :all          then collection
          when :first, :last then collection.first
          end
        else
          find_with_id(*args)
        end
      end

      def parse_find_options(options) # :nodoc:
        limit = options[:limit]

        by = options[:by] unless options[:by].blank?
        by ||= :id

        if options[:order].blank?
          order = [ :asc ]
        else
          order = options[:order]
          order = [ order ] unless order.kind_of?(Array)
        end

        unless order.nil? && order.include?(:alpha) && [ :integer, :float ].include?(schema[by][:type])
          order << :alpha
        end

        index = (options[:index] || :id)
        index = [ index ] unless index.kind_of?(Array)

        [ limit, by, order, index ]
      end

      def find_with_range(index, offset, limit) # :nodoc:
        ids = connection.lrange(index_key(*index), offset, limit)
        instanciate(connection.hgetall(key(ids.first))) if ids.any?
      end

      def find_with_id(id) # :nodoc:
        attributes = connection.hgetall(key(id))
        raise RedisModel::RecordNotFound.new("No such #{model_name} with id: #{id}") if attributes.empty?
        instanciate(attributes)
      end

      def all
        find(:all)
      end

      def first
        find(:first)
      end

      def last
        find(:last)
      end

      def method_missing(method_name, *args)
        if method_name.to_s =~ /^find_(all_by|by)_(.*)$/
          case $1
          when 'all_by'
            find :all, :index => [ $2, args.first ]
          when 'by'
            find :first, :index => [ $2, args.first ]
          end
        else
          super
        end
      end
    end

    def reload
      attributes = connection.hgetall(key)
      @attributes = {}
      self.attributes = attributes
      self.id = attributes["id"] if self.class.attribute_exists?(:id)
      persisted!
      @previously_changed = {}
      self
    end
  end
end
