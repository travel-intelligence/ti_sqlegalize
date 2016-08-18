# encoding: utf-8
module TiSqlegalize
module V2

  class SchemasController < TiSqlegalize::ApplicationController
    ensure_signed_in

    before_action do
      permitted = params.permit(:id)
      @schema_id = permitted[:id]
    end

    def index
      schemas = Schema.all

      readable_schemas = schemas.flat_map do |s|
                           current_user.can_read_schema?(s) ? [s] : []
                         end

      render_api json: schemas_to_jsonapi(readable_schemas), status: 200
    end

    def show
      raise InvalidParams unless @schema_id

      schema = begin
        Schema.find @schema_id
      rescue Schema::UnknownSchema
        nil
      end

      if schema && current_user.can_read_schema?(schema)
        render_api json: schema_to_jsonapi(schema), status: 200
      else
        render_not_found
      end
    end

    private

    def schema_to_jsonapi(schema)
      {
        data: {
          type: 'schema',
          id: schema.id,
          attributes: {
            name: schema.name,
            description: schema.description
          },
          relationships: {
            relations: {
              links: {
                related: v2_schema_relations_url(schema.id)
              }
            }
          },
          links: {
            :self => v2_schema_url(schema.id)
          }
        }
      }
    end

    def schemas_to_jsonapi(schemas)
      {
        links: {
          :self => v2_schemas_url
        },
        data: schemas.map { |s| schema_to_jsonapi(s)[:data] }
      }
    end
  end

end
end
