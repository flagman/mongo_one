module MongoOne
  module Ast
    class Parser
      def visit(node, name_prefix = nil)
        meth, rest = node
        public_send(:"visit_#{meth}", rest, name_prefix)
      end

      def visit_constrained(node, name_prefix = nil)
        visit(node[1], name_prefix)
      end

      def visit_constructor(node, name_prefix = nil)
        visit(node[0], name_prefix)
      end

      def visit_schema(node, name_prefix = nil)
        node[0].map { |n| visit(n, name_prefix) }
      end

      def detect_type_without_predicate(rest)
        return Types::Any if rest[0] == :any

        raise "Unknown type #{rest[0]}"
      end

      def visit_key(node, name_prefix = nil)
        name, _, rest = node
        predicate_node = rest[1][1]
        target_name = name_prefix ? "#{name_prefix}.#{name}" : name
        type = if predicate_node.nil?
                 detect_type_without_predicate(rest)
               else
                 visit(predicate_node, name)
               end
        if type == Array
          nested_target = rest[1][0][1][0][1][1] # skip to Array constructor
          if nested_target[0] == :predicate # Array of strings for example
            type = visit(nested_target, target_name)
            { key: target_name, type: Array, of: type }
          else
            visit(nested_target, target_name)
          end
        elsif type == Hash
          nested_target = rest[1][0] # skip to Hash constructor
          visit(nested_target, target_name)
        else
          { key: target_name, type: }
        end
      end

      def visit_predicate(node, _name_prefix = nil)
        name, args = node

        return if name.equal?(:key?)

        args.select { |x| x[0] == :type }.flatten.last
      end
    end
  end
end
