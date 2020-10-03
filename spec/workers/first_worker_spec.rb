# frozen_string_literal: true

require "workers_spec_helper"
require "medlibra/workers/first_worker"

RSpec.describe Medlibra::Workers::FirstWorker do
  it "runs worker" do
    uid = SecureRandom.hex
    user = Factory[:user, uid: uid]
    described_class.perform_async(uid)

    expect(described_class).to have_enqueued_job(uid)
  end

  it "runs worker in 10 minutes" do
    time = Time.now + 10*60
    uid = SecureRandom.hex
    user = Factory[:user, uid: uid]

    described_class.perform_at(time, uid)

    expect(described_class).to have_enqueued_job(uid).at(time)
  end
end
