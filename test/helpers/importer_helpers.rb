module ImporterHelpers
  # this intent behind this shared test assertion
  # is to measure whether the advisory_importer algorithm
  # correctly compares freshly parsed advisories against
  # the existing ones.
  #
  # it assumes that the passed in importer has just been used
  # to import the sample test advisories; it marks them as
  # processed, reimporters and - since nothing should have 
  # changed, asserts that no new advisories were marked for
  # processing.
  def assert_importer_mark_processed_idempotency(importer)
    # test that reimporting the same raw advisories
    # doesn't mark everything for reprocessing
    assert_equal 0, AdvisoryImportState.where(processed: true).count

    # at some other point it gets picked up and processed
    # by the VulnerabilityImporter, and the import state
    # gets set to processed.
    AdvisoryImportState.update_all(:processed => true)

    # when the importer runs again, we check the stuff coming in
    # against our existing advisories. if nothing has changed, 
    # nothing new should get processed.
    importer.import!
    assert_equal 0, AdvisoryImportState.where(processed: false).count
  end
end
