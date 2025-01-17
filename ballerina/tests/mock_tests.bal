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

import ballerina/test;

final string campaignMockGuid = "c4573779-0830-4eb3-bfa3-0916bda9c1a4";
final string assetMockType = "FORM";

@test:Config {
    groups: ["mock_tests"]
}
isolated function mockTestCreateCampaign() returns error? {
    PublicCampaign response = check hsCampaigns->/.post(
        payload = {
            properties: {
                "hs_name": "campaignMock",
                "hs_goal": "campaignGoalSpecifiedMock",
                "hs_notes": "someNotesForTheCampaignMock"
            }
        }
    );
    test:assertNotEquals(response?.id, "");
}

@test:Config {
    groups: ["mock_tests"]
}
isolated function testMockGetReadCampaign() returns error? {
    PublicCampaignWithAssets response = check hsCampaigns->/[campaignMockGuid];
    test:assertEquals(response.id, campaignGuid);
}

@test:Config {
    groups: ["mock_tests"]
}
isolated function testMockGetListAssets() returns error? {
    CollectionResponsePublicCampaignAssetForwardPaging response = check hsCampaigns->/[campaignMockGuid]/assets/[assetMockType];
    test:assertTrue(response?.results.length() > 0);
}
