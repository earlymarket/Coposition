ActiveAdmin.register Approval, as: "Friendship" do
  actions :all, except: [:new, :create]

  controller do
    def scoped_collection
      end_of_association_chain.where id: Approval.find_by_sql(
        <<-SQL
          select distinct on (token) *
          from (
            select *, (user_id + approvable_id) as token
            from approvals
            where status = 'accepted' and approvable_type = 'User'
          ) ds
        SQL
      ).map(&:id)
    end
  end

  index do
    selectable_column
    id_column

    column :approval do |apr|
      apr.user.username
    end
    column :approved do |apr|
      apr.approvable.username
    end
    column :date do |apr|
      apr.approval_date
    end

    actions
  end

  filter :approval_date
end
