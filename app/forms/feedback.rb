class Feedback < BaseForm
  establish_connection adapter: :nulldb,
                       schema: 'config/nulldb_schema.rb'

  attribute :problems,      :string
  attribute :suggestions,   :string
  attribute :email_address, :string

  def save
    run_callbacks :save do
      FeedbackSubmissionJob.perform_later attributes.symbolize_keys if Rails.application.config.service_now_inbox_email.present?
    end
  end

  # Loads the form object with values from the target
  def reload
    attributes.each_key { |key| send "#{key}=", target.send(:[], key.to_sym) }
  end

  # Needed as the I18n config expects this to be false so it is a create - this is different to every other form
  def persisted?
    false
  end
end