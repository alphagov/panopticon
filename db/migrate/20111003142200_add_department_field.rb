class AddDepartmentField < ActiveRecord::Migration
  def change
    add_column :artefacts, :department, :string
  end
end
