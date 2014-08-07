require 'spec_helper'

include Arel::Nodes

describe Arel do

  context 'type conversion' do
    let(:t) { Fruit.arel_table }

    # it 'should produce correct sql' do
    #   Convert.new('apple', 'tsquery').to_sql.should eq('(\'apple\')::tsquery')
    #
    #   Convert.new(t[:name], 'tsquery').to_sql.should eq('("fruits"."name")::tsquery')
    #
    #   Convert.new(NamedFunction.new('concat_ws', [' ', t[:name], t[:description]]), 'tsquery').to_sql.
    #       should eq('(concat_ws(\' \', "fruits"."name", "fruits"."description"))::tsquery')
    # end
  end

  context 'infix operation' do
    before do
      create(:fruit, name: 'apple')
      create(:fruit, name: 'orange')
      create(:fruit, name: 'pineapple')
    end

    let(:t) { Fruit.arel_table }
    let(:ar_apple) { Fruit.where(name: 'apple') }
    let(:ar_orange) { Fruit.where(name: 'orange') }
    let(:ar_pineapple) { Fruit.where(name: 'pineapple') }

    it 'should match simple strings' do
      Fruit.where(TextMatch.new(t[:name], 'apple')).should match_array(ar_apple)
      Fruit.where(TextMatch.new(t[:name], 'apples')).should match_array(ar_apple)
    end

    it 'should match string with ts_query' do
      Fruit.where(TextMatch.new(t[:name], NamedFunction.new('to_tsquery', ['orange']))).should match_array(ar_orange)
      Fruit.where(TextMatch.new(t[:name], NamedFunction.new('to_tsquery', ['oranges']))).should match_array(ar_orange)
    end

    it 'should match ts_vector with ts_query' do
      Fruit.where(TextMatch.new(NamedFunction.new('to_tsvector', ['english', t[:name]]), NamedFunction.new('to_tsquery', ['pineapple']))).should match_array(ar_pineapple)
      Fruit.where(TextMatch.new(NamedFunction.new('to_tsvector', ['english', t[:name]]), NamedFunction.new('to_tsquery', ['pineapples']))).should match_array(ar_pineapple)
    end
  end

end