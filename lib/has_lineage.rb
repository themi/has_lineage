require "has_lineage/has_lineage"

class ActiveRecord::Base
	include HasLineage::HasLineage
end
