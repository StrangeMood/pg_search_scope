module PgSearchScope
  module ModelHelper
    DEFAULT_OPTIONS = {
            :as => nil,
            :wildcard => true,
            :operator => :and,
            :normalization => 0,
            :select_rank => false,
            :language => 'simple',
            :rank_function => :ts_rank
    }
    OPERATORS = {
            :and => '&',
            :or => '|'
    }

    # Creates fulltext search scope
    #
    # == Options
    #
    # * <tt>:as</tt> - Scope name
    #
    # * <tt>:normalization</tt> - Controls rank behaviour, see http://www.postgresql.org/docs/9.0/static/textsearch-controls.html#TEXTSEARCH-RANKING
    #
    # * <tt>:wildcard</tt> - Controls search words modification:
    #                        true - add :* to ends of each search word
    #                        false - do not modify search words
    #                        :last - add :* to end of last word
    #
    # * <tt>:operator</tt> - Boolean operator (:and or :or) which combines search query
    #
    # * <tt>:select_rank</tt> - Include rank in select statement, as {scope_name}_rank
    #
    # * <tt>:language</tt> - Search language, e.g. 'simple' (without magic), 'english'
    # * <tt>:rank_function</tt> - Ranking function. Valid values are 'ts_rank' and 'ts_rank_cd'
    # * <tt>:rank_columns</tt> - If you want to sort table by rank only by specific fields - input column names here
    #
    # == Usage
    #
    #   search_scope_for :name
    #   -->
    #   search_by_name("Ivan")
    #
    #   search_scope_for :name, :address,
    #                    :wildcard => :last
    #   -->
    #   search_by_name_and_address("Ivan, Aurora st.", :select_rank => true)
    #

    def search_scope_for *column_names
      scope_options = DEFAULT_OPTIONS.merge column_names.extract_options!

      scope_name = scope_options[:as] || "search_by_#{column_names.join('_and_')}"

      scope scope_name, proc { |search_string, options|
        options = scope_options.merge(options || {})
        search_string ||= ''

        terms = search_string.scan(/[\p{Lu}\p{Ll}\d][\p{Lu}\p{Ll}\d\.'@]*/u)

        if terms.present?
          case options[:wildcard]
            when true then
              terms.map! { |s| "#{s}:*" }
            when :last then
              terms[-1] = "#{terms[-1]}:*"
          end

          t = arel_table
          n = Arel::Nodes

          columns = column_names.map {|n| t[n] }

          tsvector = n::TsVector.new(columns, options)
          tsquery  = n::TsQuery.new(terms, options)

          rank_tsvector = tsvector
          if options[:rank_columns].present?
            rank_columns = options[:rank_columns].map {|n| t[n] }
            rank_tsvector = n::TsVector.new(rank_columns, options)
          end

          rank = n::NamedFunction.new(scope_options[:rank_function], [rank_tsvector, tsquery, options[:normalization]])

          search_scope = self

          if options[:select_rank]
            search_scope = search_scope.select(n::As.new(rank, "#{scope_name}_rank"))
          end

          search_scope.where(n::TextMatch.new(tsvector, tsquery)).order(n::Descending.new(rank))
        else
          if options[:select_rank]
            self.select("0 #{scope_name}_rank")
          end
        end
      }
    end
  end
end

ActiveRecord::Base.send :extend, PgSearchScope::ModelHelper