module HasLineage
  class GeneralException < RuntimeError; end

  class MoveException < GeneralException; end
end