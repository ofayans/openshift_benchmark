module ApplicationHelper
  def link_to_remove_dockerserver(name, f)
    f.hidden_field(:_destroy) + link_to(name, "#removebutton", :onclick => "remove_dockerserver(this)", :id => "removebutton")
  end

  def link_to_add_dockerserver(name, f, association)
    new_object = f.object.send(association).build
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("dockerserver_fields", :f => builder)
    end
    link_to(name, "#addserver", :id => "addserver", :onclick => "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

end
