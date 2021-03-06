require 'test_helper'
class ApkComparatorTest < ActiveSupport::TestCase
  EQ = 0
  GT = 1
  LT = -1

  it "correctly compares versions" do
    cases = [["1.1.6-r0", "1.1.6-r0", EQ],
             ["1.1.6-r0", "1.1.6-r1", LT],
             ["1.1.7-r0", "1.1.6-r1", GT],

             ["6.3.008-r4", "6.3.008-r4", EQ],
             ["6.3.008-r4", "6.3.008-r5", LT],
             ["6.3.010-r4", "6.3.008-r4", GT],

             # TODO should this evaluate to EQ? Because it doesn't :(
             # ["6.3.008-r4", "6.3.8-r4", EQ],

             ["4.3.46-r5", "4.3.46-r5", EQ],
             ["20161130-r0", "20161130-r0", EQ],
             ["20161129-r0", "20161130-r0", LT],
             ["20161130-r1", "20161130-r0", GT],

             ["1.8.19_p1-r0", "1.8.19_p1-r0", EQ],

             ["1.8.19_p2-r0", "1.8.19_p1-r0", GT],
             ["1.8.19_p2-r0", "1.8.19_p1-r1", GT],

             ["6.04_pre1-r0", "6.04_pre1-r0", EQ],
             ["6.04_pre2-r0", "6.04_pre1-r0", GT],
             ["6.04_pre1-r0", "6.04_pre1-r1", LT],

             ["1.1.15-r6", "1.1.15-r6", EQ],
             ["0.7-r1", "0.7-r1", EQ],
             ["1.3-r0", "1.3-r0", EQ],
             ["3.5.1-r0", "3.5.1-r0", EQ],
             ["2.28.2-r1", "2.28.2-r1", EQ],
             ["1.43.3-r0", "1.43.3-r0", EQ],
             ["1.43.3-r0", "1.43.3-r0", EQ],
             ["1.25-r2", "1.25-r2", EQ],

             ["2.02.168-r3", "2.02.168-r3", EQ],
             ["2.03.168-r3", "2.02.168-r3", GT],

             ["1.7.2-r1", "1.7.2-r1", EQ],
             ["5.2.2-r1", "5.2.2-r1", EQ],

             ["23-r1", "23-r1", EQ],
             ["23-r1", "24-r1", LT],
             ["23-r2", "24-r1", LT],
             ["23-r2", "23-r1", GT],

             ["3.0.9-r1", "3.0.9-r1", EQ],
             ["4.4.45-r0", "4.4.45-r0", EQ],
             ["2.4.4-r0", "2.4.4-r0", EQ],

             ["7.4_p1-r1", "7.4_p1-r0", GT],
             ["7.4_p1-r1", "7.4_p1-r2", LT],
             ["7.4_p1-r1", "7.3_p1-r1", GT],
             ["7.4_p1-r1", "7.5_p1-r1", LT]]

    cases.each do |(v1, v2, res)|
      assert_equal res, ApkComparator.new(v1).vercmp(v1, v2), "#{v1} <=> #{v2} was not #{res}"
    end
  end

  it "correctly identifies versions which satisfy constraints" do
    cases = [["1.1.6-r0", "1.1.6-r0", true],
             ["1.1.6-r0", "1.1.6-r1", false],
             ["1.1.7-r0", "1.1.6-r1", true],

             ["6.3.008-r4", "6.3.008-r4", true],
             ["6.3.008-r4", "6.3.008-r5", false],
             ["6.3.010-r4", "6.3.008-r4", true],

             # TODO should this evaluate to EQ? Because it doesn't :(
             # ["6.3.008-r4", "6.3.8-r4", EQ],

             ["4.3.46-r5", "4.3.46-r5", true],
             ["20161130-r0", "20161130-r0", true],
             ["20161129-r0", "20161130-r0", false],
             ["20161130-r1", "20161130-r0", true],

             ["1.8.19_p1-r0", "1.8.19_p1-r0", true],

             ["1.8.19_p2-r0", "1.8.19_p1-r0", true],
             ["1.8.19_p2-r0", "1.8.19_p1-r1", true],

             ["6.04_pre1-r0", "6.04_pre1-r0", true],
             ["6.04_pre2-r0", "6.04_pre1-r0", true],
             ["6.04_pre1-r0", "6.04_pre1-r1", false],

             ["1.1.15-r6", "1.1.15-r6", true],
             ["0.7-r1", "0.7-r1", true],
             ["1.3-r0", "1.3-r0", true],
             ["3.5.1-r0", "3.5.1-r0", true],
             ["2.28.2-r1", "2.28.2-r1", true],
             ["1.43.3-r0", "1.43.3-r0", true],
             ["1.43.3-r0", "1.43.3-r0", true],
             ["1.25-r2", "1.25-r2", true],

             ["2.02.168-r3", "2.02.168-r3", true],
             ["2.03.168-r3", "2.02.168-r3", true],

             ["1.7.2-r1", "1.7.2-r1", true],
             ["5.2.2-r1", "5.2.2-r1", true],

             ["23-r1", "23-r1", true],
             ["23-r1", "24-r1", false],
             ["23-r2", "24-r1", false],
             ["23-r2", "23-r1", true],

             ["3.0.9-r1", "3.0.9-r1", true],
             ["4.4.45-r0", "4.4.45-r0", true],
             ["2.4.4-r0", "2.4.4-r0", true]]

    cases.each do |(v1, v2, res)|
      assert_equal res, ApkComparator.new(v1).satisfies?(v2), "#{v1}.satisfies? #{v2} was not #{res}"
    end
  end
end
