module Mongoid
  module Document
    module ClassMethods
      def sort_by(sort_column, sort_direction)
        return nil unless ! sort_direction.blank? and [ :asc, :desc ].include?(sort_direction)
        return nil unless ! sort_column.blank? and self.fields.has_key?(sort_column.to_s)
        return self.send(sort_direction, sort_column)
      end
    end
  end
end

