class Artefact < ActiveRecord::Base
  def admin_url
    Plek.current.publisher + '/admin/' + kind.tableize + '/new?' + query_string
  end

  def query_string
    [
      query_param(:name),
      query_param(:slug),
      query_param(:tags)
    ].join '&'
  end
  private :query_string

  def query_param attribute
    "#{CGI.escape(kind.to_s)}[#{CGI.escape(attribute.to_s)}]=#{CGI.escape(read_attribute(attribute).to_s)}"
  end
  private :query_param
end
