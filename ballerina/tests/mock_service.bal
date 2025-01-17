import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new (9090);

http:Service mockService = service object {
    resource function post .() returns PublicCampaign{
        return {
            id: "12345_Mock",
            properties: {
                "hs_name": "campaignMock",
                "hs_goal": "campaignGoalSpecifiedMock",
                "hs_notes": "someNotesForTheCampaignMock"
            },
            createdAt:"2021-08-25T10:00:00Z",
            updatedAt: "2021-08-25T10:00:00Z"
        };
    };

    resource function get [string campaignMockGuid]/assets/FORM() returns CollectionResponsePublicCampaignAssetForwardPaging {
        return {
            "results": [
        {
            "id": "88047023-7777-40a1-b74b-4b1139e8d45b",
            "name": "New form (January 3, 2025 4:37:41 AM EST)"
        }
    ]
        };
    };

    resource function get [string campaignMockGuid]() returns PublicCampaignWithAssets {
        return {
            "id": "c4573779-0830-4eb3-bfa3-0916bda9c1a4",
            "properties": {},
            "createdAt": "2025-01-07T04:45:53.011Z",
            "updatedAt": "2025-01-08T09:52:24.054Z",
            "assets": {
                "FORM": {
                    "results": [
                        {
                            "id": "88047023-7777-40a1-b74b-4b1139e8d45b",
                            "name": "New form (January 3, 2025 4:37:41 AM EST)"
                        }
                    ]
                }
            }
        };
    };
};

function init() returns error? {
    log:printInfo("Initializing mock service");
    check httpListener.attach(mockService, "/marketing/v3/campaigns");
    check httpListener.'start();
}
