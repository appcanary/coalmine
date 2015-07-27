Analytics = Segment::Analytics.new({
    write_key: '4d4VwYpHGbxQI5vUiRzOwVsV3yw7PTxs',
    on_error: Proc.new { |status, msg| print msg }
})
