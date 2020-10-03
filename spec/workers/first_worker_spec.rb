# frozen_string_literal: true

require "workers_spec_helper"
require "medlibra/workers/first_worker"

RSpec.describe Medlibra::Workers::FirstWorker do
  it "runs worker" do
    uid = SecureRandom.hex
    Factory[:user, uid: uid]

    users_repo = instance_double(Medlibra::Repositories::UsersRepo)
    Medlibra::Container.stub("repositories.users_repo", users_repo)

    allow(users_repo).to receive(:by_uid).with(uid)

    described_class.new.perform(uid)

    expect(users_repo).to have_received(:by_uid).with(uid)
    Medlibra::Container.unstub("repositories.users_repo")
  end

  it "runs worker in 10 minutes" do
    time = Time.now + 10 * 60
    uid = SecureRandom.hex
    Factory[:user, uid: uid]

    described_class.perform_at(time, uid)

    expect(described_class).to have_enqueued_job(uid).at(time)
  end
end
