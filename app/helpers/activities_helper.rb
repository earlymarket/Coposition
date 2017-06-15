module ActivitiesHelper
  def link_to_activity(activity)
    if activity.trackable
      link_to(activity.trackable_type,
        Rails.application.routes.url_helpers.activities_path(filter: true, trackable_type: activity.trackable_type,
                                                             trackable_id: activity.trackable.id))
    else
      activity.trackable_type
    end
  end
end
