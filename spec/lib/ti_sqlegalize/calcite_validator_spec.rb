# encoding: utf-8
require 'rails_helper'
require 'ti_sqlegalize/calcite_validator'
require 'ti_sqlegalize/zmq_socket'

RSpec.describe TiSqlegalize::CalciteValidator do

  let(:simple_sql) { "select * from hr.emps" }

  it "communicates successfully" do

    endpoint = "tcp://127.0.0.1:5555"

    rep = with_a_calcite_server_at(endpoint) do
      socket = TiSqlegalize::ZMQSocket.new(endpoint)
      validator = TiSqlegalize::CalciteValidator.new(socket)
      validator.parse(simple_sql, [hr_schema])
    end

    expect(rep).to be_valid
    expect(rep.sql).to eq("SELECT *\nFROM `HR`.`EMPS`")
  end
end
