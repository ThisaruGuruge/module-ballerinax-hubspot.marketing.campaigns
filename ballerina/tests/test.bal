// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/oauth2;
import ballerina/test;
import ballerina/time;
import ballerina/http;

configurable boolean isLiveTestsEnabled = false;
configurable string clientId = "testClientId";
configurable string clientSecret = "testClientSecret";
configurable string refreshToken = "testRefreshToken";

final Client hsCampaigns = check initClient();

isolated function initClient() returns Client|error {
    if isLiveTestsEnabled {
        OAuth2RefreshTokenGrantConfig auth = {
            clientId,
            clientSecret,
            refreshToken,
            credentialBearer: oauth2:POST_BODY_BEARER
        };
        return new ({auth});
    }
    return new ({
        auth: {
            token: "testToken"
        }
    }, serviceUrl = "http://localhost:9090/marketing/v3/campaigns");
}

string campaignGuid2 = "";
configurable string campaignGuid = "c4573779-0830-4eb3-bfa3-0916bda9c1a4";
configurable string assetType = "FORM";
configurable string assetID = "";

configurable string sampleCampaignGuid1 = "";
configurable string sampleCampaignGuid2 = "";
configurable string sampleCampaignGuid3 = "";
configurable string sampleCampaignGuid4 = "";

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testGetSearchMarketingCampaigns() returns error? {
    CollectionResponseWithTotalPublicCampaignForwardPaging response = check hsCampaigns->/.get();
    test:assertTrue(response.results.length() > 0);
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
function testPostCreateMarketingCampaigns() returns error? {
    PublicCampaign response = check hsCampaigns->/.post(
        payload = {
            properties: {
                "hs_name": "campaign" + time:utcNow().toString(),
                "hs_goal": "campaignGoalSpecified",
                "hs_notes": "someNotesForTheCampaign"
            }
        }
    );
    test:assertNotEquals(response.id, "");
    campaignGuid2 = response?.id;
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testGetReadACampaign() returns error? {
    PublicCampaignWithAssets response = check hsCampaigns->/[campaignGuid];
    test:assertEquals(response?.id, campaignGuid);
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testPatchUpdateCampaigns() returns error? {
    PublicCampaign response = check hsCampaigns->/[campaignGuid].patch(
        payload = {
            properties: {
                "hs_goal": "updatedCampaignGoal",
                "hs_notes": "updatedNotesForTheCampaign"
            }
        }
    );
    test:assertEquals(response?.id, campaignGuid);
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testPostBatchCreate() returns error? {
    BatchResponsePublicCampaign|BatchResponsePublicCampaignWithErrors response = check hsCampaigns->/batch/create.post(
        payload = {
            "inputs": [
                {
                    "properties": {
                        "hs_name": "batchCampaign" + time:utcToString(time:utcNow()),
                        "hs_goal": "batchCampaignGoalSpecified"
                    }
                }
            ]
        }
    );
    test:assertEquals(response?.status, "COMPLETE");
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testPostBatchUpdate() returns error? {
    BatchResponsePublicCampaign|BatchResponsePublicCampaignWithErrors response = check hsCampaigns->/batch/update.post(
        payload = {
            "inputs": [
                {
                    "id": sampleCampaignGuid1,
                    "properties": {
                        "hs_goal": "updatedGoal",
                        "hs_notes": "updatedNote"
                    }
                }
            ]
        }
    );
    test:assertEquals(response?.status, "COMPLETE");
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testPostBatchRead() returns error? {
    BatchResponsePublicCampaignWithAssets|BatchResponsePublicCampaignWithAssetsWithErrors response =
        check hsCampaigns->/batch/read.post(
        payload = {
            "inputs": [
                {
                    "id": sampleCampaignGuid2
                }
            ]
        }
    );
    test:assertEquals(response?.status, "COMPLETE");
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testGetReportsRevenue() returns error? {
    RevenueAttributionAggregate response = check hsCampaigns->/[campaignGuid]/reports/revenue;
    test:assertTrue(response?.revenueAmount is decimal);
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testGetReportsMetrics() returns error? {
    MetricsCounters response = check hsCampaigns->/[campaignGuid]/reports/metrics;
    test:assertTrue(response?.sessions >= 0);
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testGetListAssets() returns error? {
    CollectionResponsePublicCampaignAssetForwardPaging response = check hsCampaigns->/[campaignGuid]/assets/[assetType];
    test:assertTrue(response?.results.length() > 0);

}

@test:Config {
    dependsOn: [testDeleteRemoveAssetAssociation],
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testPutAddAssetAssociation() returns error? {
    http:Response response = check hsCampaigns->/[campaignGuid]/assets/[assetType]/[assetID].put();
    test:assertEquals(response.statusCode, 204);
}

@test:Config {
    dependsOn: [testGetListAssets],
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testDeleteRemoveAssetAssociation() returns error? {
    http:Response response = check hsCampaigns->/[campaignGuid]/assets/[assetType]/[assetID].delete();
    test:assertEquals(response.statusCode, 204);
}

@test:Config {
    dependsOn: [testPostCreateMarketingCampaigns],
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
function testDeleteCampaign() returns error? {
    http:Response response = check hsCampaigns->/[campaignGuid2].delete();
    test:assertEquals(response.statusCode, 204);
}

@test:Config {
    groups: ["live_tests"],
    enable: isLiveTestsEnabled
}
isolated function testPostDeleteABatchOfCampaigns() returns error? {
    http:Response response = check hsCampaigns->/batch/archive.post(
        payload = {
            "inputs": [
                {
                    "id": sampleCampaignGuid3
                },
                {
                    "id": sampleCampaignGuid4
                }
            ]
        }
    );
    test:assertEquals(response.statusCode, 204);
}
