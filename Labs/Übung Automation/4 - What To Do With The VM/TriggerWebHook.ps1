$webhook =    # "https://s2events.azure-automation.net/webhooks?token=XrZB6tmPRWoaxtNh0e2HQCNnEv%2bwCthmCBe3WH%2fTvsI%3d"
$response = Invoke-WebRequest -Method Post -Uri $webhook

"Azure responded: {0}" -f $response.Content

