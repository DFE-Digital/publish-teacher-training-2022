require 'rails_helper'

describe CourseDecorator do
  let(:course_jsonapi) {
    jsonapi(:course, last_published_at: '2019-03-05T14:42:34Z').to_resource
  }
  let(:course) { course_jsonapi.decorate }

  it "returns last_published_at formatted" do
    expect(course.last_published_at).to eq('5 March 2019')
  end
end
