class JSONAPIMockSerializable
  attr_reader :attributes,
              :id,
              :missing_relationships,
              :present_relationships,
              :relationships,
              :type

  def initialize(id, type, attributes:, relationships: {})
    @attributes = attributes
    @id = id
    @relationships = relationships
    @missing_relationships = relationships.select { |_r, v| v.nil? }
    @present_relationships = relationships.reject { |_r, v| v.nil? }
    @type = type
  end

  def get_related
    (
      present_relationships.values +
      present_relationships.values.flatten.map(&:get_related)
    ).flatten.uniq
  end

  def render
    included_relationships = get_related.map(&:to_jsonapi_data)
    {
      data: to_jsonapi_data,
      included: included_relationships
    }
  end

  def to_jsonapi_data
    relationships_jsonapi = relationships.transform_values do |data|
      if data.nil?
        {
          meta: { included: false }
        }
      elsif data.is_a? Array
        {
          data: data.map(&:to_jsonapi_relationship)
        }
      else
        {
          data: data.to_jsonapi_relationship
        }
      end
    end
    data = {
      id: id.to_s,
      type: type,
      attributes: attributes
    }
    if relationships_jsonapi.any?
      data.merge!(relationships: relationships_jsonapi)
    end
    data
  end

  def to_jsonapi_relationship
    {
      id: id.to_s,
      type: type
    }
  end
end
