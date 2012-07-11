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
          limit, by, order, fields = parse_find_options(args.first, options)
          index, indices = index_from_find_options(options)

          results = if indices
            connection.multi do |multi|
              connection.sinterstore(index, *indices)
              _find(index, :fields => fields, :by => by, :order => order, :limit => limit)
              connection.del(index)
            end[1]
          else
            _find(index, :fields => fields, :by => by, :order => order, :limit => limit)
          end

          collection = results.collect do |values|
            instanciate(Hash[ *fields.zip(values).flatten ])
          end

          case args.first
          when :all          then collection
          when :first, :last then collection.first
          end
        else
          find_with_id(*args)
        end
      end

#      def find_with_range(index, offset, limit) # :nodoc:
#        ids = connection.lrange(index_key(*index), offset, limit)
#        instanciate(connection.hgetall(key(ids.first))) if ids.any?
#      end

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

      private
        def _find(index, options) # :nodoc:
          connection.sort(index,
            :get   => options[:fields].collect { |k| hkey(k) },
            :by    => hkey(options[:by]),
            :order => options[:order].join(" ").upcase,
            :limit => options[:limit]
          )
        end

        def index_from_find_options(options) # :nodoc:
          if options[:conditions].nil? || options[:conditions].empty?
            index = parse_find_index(options[:index] || :id)
          else
            raise RedisModelError.new(":index option isn't compatible with the :conditions option.") if options[:index]

            if options[:conditions].size == 1
              index = parse_find_index(options[:conditions].flatten)
            else
              index = index_key(options[:conditions].flatten.join(':'))
              indices = options[:conditions].collect { |k,v| index_key(k, v) }
            end
          end

          [ index, indices ]
        end

        def parse_find_index(index) # :nodoc:
          index = [ index ] unless index.kind_of?(Array)
          index_key(*index)
        end

        def parse_find_options(scope, options) # :nodoc:
          limit = options[:limit]
          by = if options[:by].blank? then :id else options[:by] end

          if options[:order].blank?
            order = [ :asc ]
          else
            order = options[:order]
            order = [ order ] unless order.kind_of?(Array)
          end

          unless order.nil? && order.include?(:alpha) && [ :integer, :float ].include?(schema[by][:type])
            order << :alpha
          end

          case scope
          when :all
            # pass
          when :first
            limit = [ 0, 1 ]
          when :last
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
          [ limit, by, order, fields ]
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
