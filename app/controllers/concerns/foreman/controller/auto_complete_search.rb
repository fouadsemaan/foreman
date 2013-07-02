module Foreman::Controller::AutoCompleteSearch
  extend ActiveSupport::Concern

  def auto_complete_search
    begin
      model = controller_name == "hosts" ? Host::Managed : model_of_controller
      @items = model.complete_for(params[:search])
      @items = @items.map do |item|
        category = (['and','or','not','has'].include?(item.to_s.sub(/^.*\s+/,''))) ? 'Operators' : ''
        part = item.to_s.sub(/^.*\b(and|or)\b/i) {|match| match.sub(/^.*\s+/,'')}
        completed = item.to_s.chomp(part)
        {:completed => completed, :part => part, :label => item, :category => category}
      end
    rescue ScopedSearch::QueryNotSupported => e
      @items = [{:error =>e.to_s}]
    end
    render :json => @items
  end

  def invalid_search_query(e)
    error (_("Invalid search query: %s") % e)
    redirect_to :back
  end

end
