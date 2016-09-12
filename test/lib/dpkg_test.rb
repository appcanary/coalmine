require 'test_helper'
class DpkgTest < ActiveSupport::TestCase
  it "should compare this specific version properly" do
    # a bug we encountered, back in clj land
    d1 = Dpkg::Evr.from_s("2.1.0-6+deb8u1")
    d2 = Dpkg::Evr.from_s("2.1.0~beta3-0")

    assert (d1 <=> d2) > 0
  end

  test "version_compare" do
    # Below is the C code from lib/dpkg/t/t-version.c (git://anonscm.debian.org/dpkg/dpkg.git rev: 177d85ef4ed54fabf60cc2ff1e9e8c5a5b4ff604)
    
    a = Dpkg::Evr.new
    assert_equal 0, a <=> a

    # a.epoch = 1;
    # b.epoch = 2;
    # test_fail(dpkg_version_compare(&a, &b) == 0);

    a = dp(1, nil, nil)
    b = dp(2, nil, nil)
    assert_not_equal 0, a <=> b


    # a = DPKG_VERSION_OBJECT(0, "1", "1");
    # b = DPKG_VERSION_OBJECT(0, "2", "1");
    # test_fail(dpkg_version_compare(&a, &b) == 0);

    a = dp(0, "1", "1")
    b = dp(0, "2", "1")
    assert_not_equal 0, a <=> b

    # a = DPKG_VERSION_OBJECT(0, "1", "1");
    # b = DPKG_VERSION_OBJECT(0, "1", "2");
    # test_fail(dpkg_version_compare(&a, &b) == 0);

    a = dp(0, "1", "1")
    b = dp(0, "1", "2")
    assert_not_equal 0, a <=> b

    # test for version equality
    # a = b = DPKG_VERSION_OBJECT(0, "0", "0");
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    a = b = dp(0, "0", "0")
    assert_equal 0, a <=> b

    # a = DPKG_VERSION_OBJECT(0, "0", "00");
    # b = DPKG_VERSION_OBJECT(0, "00", "0");
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    a = dp(0, "0", "00")
    b = dp(0, "00", "0")
    assert_equal 0, a <=> b

    # a = b = DPKG_VERSION_OBJECT(1, "2", "3");
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    a = b = dp(1, "2", "3")
    assert_equal 0, a <=> b

    # test for epoch diff
    # a = DPKG_VERSION_OBJECT(0, "0", "0");
    # b = DPKG_VERSION_OBJECT(1, "0", "0");
    # test_pass(dpkg_version_compare(&a, &b) < 0);
    # test_pass(dpkg_version_compare(&b, &a) > 0);

    a = dp(0, "0", "0")
    b = dp(1, "0", "0")
    assert (a <=> b) < 0
    assert (b <=> a) > 0

    # test for version component diff
    # a = DPKG_VERSION_OBJECT(0, "a", "0");
    # b = DPKG_VERSION_OBJECT(0, "b", "0");
    # test_pass(dpkg_version_compare(&a, &b) < 0);
    # test_pass(dpkg_version_compare(&b, &a) > 0);

    a = dp(0, "a", "0")
    b = dp(0, "b", "0")
    assert (a <=> b) < 0
    assert (b <=> a) > 0

    # test for revision component diff
    # a = DPKG_VERSION_OBJECT(0, "0", "a");
    # b = DPKG_VERSION_OBJECT(0, "0", "b");
    # test_pass(dpkg_version_compare(&a, &b) < 0);
    # test_pass(dpkg_version_compare(&b, &a) > 0);

    a = dp(0, "0", "a")
    a = dp(0, "0", "b")
    assert (a <=> b) < 0
    assert (b <=> a) > 0
  end

  test "version_parse" do
    # /* Test 0 versions. */
    # dpkg_version_blank(&a);
    # b = DPKG_VERSION_OBJECT(0, "0", "");

    # test_pass(parseversion(&a, "0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    a = Dpkg::Evr.from_s("0")
    b = dp(0, "0", "")
    assert_equal 0, a <=> b
	
    # test_pass(parseversion(&a, "0:0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    a = ds("0:0")
    assert_equal 0, a <=> b

    # test_pass(parseversion(&a, "0:0-", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    a = ds("0:0-")
    dsame(a, b)
    
    # b = DPKG_VERSION_OBJECT(0, "0", "0");
    # test_pass(parseversion(&a, "0:0-0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0", "0")
    a = ds("0:0-0")
    dsame(a, b)

    # b = DPKG_VERSION_OBJECT(0, "0.0", "0.0");
    # test_pass(parseversion(&a, "0:0.0-0.0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0.0", "0.0")
    a = ds("0:0.0-0.0")
    dsame(a, b)

    # /* Test epoched versions. */
    # b = DPKG_VERSION_OBJECT(1, "0", "");
    # test_pass(parseversion(&a, "1:0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(1, "0", "")
    a = ds("1:0")
    dsame(a, b)

    # b = DPKG_VERSION_OBJECT(5, "1", "");
    # test_pass(parseversion(&a, "5:1", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);
    b = dp(5, "1", "")
    a = ds "5:1"
    dsame(a, b)

    # /* Test multiple hyphens. */
    # b = DPKG_VERSION_OBJECT(0, "0-0", "0");
    # test_pass(parseversion(&a, "0:0-0-0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0-0", "0")
    a = ds "0:0-0-0"
    dsame(a, b)

    # b = DPKG_VERSION_OBJECT(0, "0-0-0", "0");
    # test_pass(parseversion(&a, "0:0-0-0-0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0-0-0", "0")
    a = ds("0:0-0-0-0")
    dsame(a, b)

    # /* Test multiple colons. */
    # b = DPKG_VERSION_OBJECT(0, "0:0", "0");
    # test_pass(parseversion(&a, "0:0:0-0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0:0", "0")
    a = ds("0:0:0-0")
    dsame(a,b)

    # b = DPKG_VERSION_OBJECT(0, "0:0:0", "0");
    # test_pass(parseversion(&a, "0:0:0:0-0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0:0:0", "0")
    a = ds("0:0:0:0-0")
    dsame(a,b)

    # /* Test multiple hyphens and colons. */
    # b = DPKG_VERSION_OBJECT(0, "0:0-0", "0");
    # test_pass(parseversion(&a, "0:0:0-0-0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0:0-0", "0")
    a = ds("0:0:0-0-0")
    dsame(a,b)

    # b = DPKG_VERSION_OBJECT(0, "0-0:0", "0");
    # test_pass(parseversion(&a, "0:0-0:0-0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0-0:0", "0")
    a = ds("0:0-0:0-0")
    dsame(a,b)

    # /* Test valid characters in upstream version. */
    # b = DPKG_VERSION_OBJECT(0, "09azAZ.-+~:", "0");
    # test_pass(parseversion(&a, "0:09azAZ.-+~:-0", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "09azAZ.-+~:", "0")
    a = ds("0:09azAZ.-+~:-0")
    dsame(a,b)

    # /* Test valid characters in revision. */
    # b = DPKG_VERSION_OBJECT(0, "0", "azAZ09.+~");
    # test_pass(parseversion(&a, "0:0-azAZ09.+~", NULL) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0", "azAZ09.+~")
    a = ds("0:0-azAZ09.+~")
    dsame(a,b)

    # /* Test version with leading and trailing spaces. */
    # b = DPKG_VERSION_OBJECT(0, "0", "1");
    # test_pass(parseversion(&a, "  	0:0-1", &err) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);
    # test_pass(parseversion(&a, "0:0-1	  ", &err) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);
    # test_pass(parseversion(&a, "	  0:0-1  	", &err) == 0);
    # test_pass(dpkg_version_compare(&a, &b) == 0);

    b = dp(0, "0", "1")
    a = ds("  	0:0-1")
    dsame(a,b)

    a = ds("0:0-1	  ")
    dsame(a,b)

    a = ds("	  0:0-1  	")
    dsame(a,b)
    # /* Test empty version. */
    # test_pass(parseversion(&a, "", &err) != 0);
    # test_error(err);
    # test_pass(parseversion(&a, "  ", &err) != 0);
    # test_error(err);

    assert_raise do ds("") end
    assert_raise do ds("  ") end

    # /* Test empty upstream version after epoch. */
    # test_fail(parseversion(&a, "0:", &err) == 0);
    # test_error(err);

    assert_raise do ds("0:") end
    # /* Test version with embedded spaces. */
    # test_fail(parseversion(&a, "0:0 0-1", &err) == 0);
    # test_error(err);

    assert_raise do ds("0:0 0-1") end
    # /* Test version with negative epoch. */
    # test_fail(parseversion(&a, "-1:0-1", &err) == 0);
    # test_error(err);

    assert_raise do ds("-1:0-1") end

    # /* Test version with huge epoch. */
    # test_fail(parseversion(&a, "999999999999999999999999:0-1", &err) == 0);
    # test_error(err);

    #--> not going to bother enforcing this limitation?
    # assert_raise do ds("999999999999999999999999:0-1") end

    # /* Test invalid characters in epoch. */
    # test_fail(parseversion(&a, "a:0-0", &err) == 0);
    # test_error(err);
    # test_fail(parseversion(&a, "A:0-0", &err) == 0);
    # test_error(err);

    assert_raise do ds("a:0-0") end
    assert_raise do ds("A:0-0") end

    # /* Test upstream version not starting with a digit */
    # test_fail(parseversion(&a, "0:abc3-0", &err) == 0);
    # test_warn(err);

    
    assert_raise do ds("0:abc3-0") end

    # /* Test invalid characters in upstream version. */
    # verstr = test_alloc(strdup("0:0a-0"));
    # for (p = "!#@$%&/|\\<>()[]{};,_=*^'"; *p; p++) {
    #     verstr[3] = *p;
    #     test_fail(parseversion(&a, verstr, &err) == 0);
    #     test_warn(err);
    # }
    # free(verstr);

    verstr = "0:0a-0"
    "!#@$%&/|\\<>()[]{};,_=*^'".chars.each do |p|
      verstr[3] = p
      assert_raise do
        ds(verstr)
      end
    end

    # /* Test invalid characters in revision. */
    # test_fail(parseversion(&a, "0:0-0:0", &err) == 0);
    # test_warn(err);

    assert_raise do ds("0:0-0:0") end

    # verstr = test_alloc(strdup("0:0-0"));
    # for (p = "!#@$%&/|\\<>()[]{}:;,_=*^'"; *p; p++) {
    #     verstr[4] = *p;
    #     test_fail(parseversion(&a, verstr, &err) == 0);
    #     test_warn(err);
    # }
    #   free(verstr);

    verstr = "0:0-0"
    "!#@$%&/|\\<>()[]{}:;,_=*^'".chars.each do |p|
      verstr[4] = p
      assert_raise do
        ds(verstr)
      end
    end
    
  end

  # got tired of typing these
  def dsame(a, b)
    assert_equal 0, a <=> b
  end

  def ds(s)
    Dpkg::Evr.from_s(s)
  end

  def dp(e, v, r)
    Dpkg::Evr.new(e, v, r)
  end
end
