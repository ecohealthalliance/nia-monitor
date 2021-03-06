define({ "api": [
  {
    "success": {
      "fields": {
        "Success 200": [
          {
            "group": "Success 200",
            "optional": false,
            "field": "varname1",
            "description": "<p>No type.</p>"
          },
          {
            "group": "Success 200",
            "type": "String",
            "optional": false,
            "field": "varname2",
            "description": "<p>With type.</p>"
          }
        ]
      }
    },
    "type": "",
    "url": "",
    "version": "0.0.0",
    "filename": "./public/.apidocs/main.js",
    "group": "_mnt_t11_nia_monitor_public__apidocs_main_js",
    "groupTitle": "_mnt_t11_nia_monitor_public__apidocs_main_js",
    "name": ""
  },
  {
    "success": {
      "fields": {
        "Success 200": [
          {
            "group": "Success 200",
            "optional": false,
            "field": "varname1",
            "description": "<p>No type.</p>"
          },
          {
            "group": "Success 200",
            "type": "String",
            "optional": false,
            "field": "varname2",
            "description": "<p>With type.</p>"
          }
        ]
      }
    },
    "type": "",
    "url": "",
    "version": "0.0.0",
    "filename": "./public/static/main.js",
    "group": "_mnt_t11_nia_monitor_public_static_main_js",
    "groupTitle": "_mnt_t11_nia_monitor_public_static_main_js",
    "name": ""
  },
  {
    "type": "get",
    "url": "frequentAgents",
    "title": "Request frequent agents",
    "name": "frequentAgents",
    "group": "agent",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "promedFeedId",
            "defaultValue": "all",
            "description": "<p>The ProMED-mail regional feed to query</p>"
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "agent",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/frequentAgents"
      }
    ]
  },
  {
    "type": "get",
    "url": "recentAgents",
    "title": "Request recent Agents",
    "name": "recentAgents",
    "group": "agent",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "promedFeedId",
            "defaultValue": "all",
            "description": "<p>The ProMED-mail regional feed to query</p>"
          },
          {
            "group": "Parameter",
            "type": "ISODateString",
            "optional": false,
            "field": "start",
            "defaultValue": "2",
            "description": "<p>weeks ago</p>"
          },
          {
            "group": "Parameter",
            "type": "ISODateString",
            "optional": false,
            "field": "end",
            "defaultValue": "today",
            "description": ""
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "agent",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/recentAgents"
      }
    ]
  },
  {
    "type": "get",
    "url": "recentDescriptorMentions",
    "title": "Request descriptive phrases used for the given agent.",
    "name": "recentDescriptorMentions",
    "group": "agent",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "descriptor",
            "description": ""
          },
          {
            "group": "Parameter",
            "type": "String",
            "optional": true,
            "field": "term",
            "description": ""
          },
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "promedFeedId",
            "defaultValue": "all",
            "description": "<p>The ProMED-mail regional feed to query</p>"
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "agent",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/recentDescriptorMentions"
      }
    ]
  },
  {
    "type": "get",
    "url": "trendingAgents/:range",
    "title": "Request trending agents in a time range (year, month, week)",
    "name": "trendingAgents",
    "group": "agent",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "range",
            "description": "<p>(year, month, week)</p>"
          },
          {
            "group": "Parameter",
            "type": "ISODateString",
            "optional": false,
            "field": "trendingDate",
            "defaultValue": "today",
            "description": "<p>The date of interest</p>"
          },
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "promedFeedId",
            "defaultValue": "all",
            "description": "<p>The ProMED-mail regional feed to query</p>"
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "agent",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/trendingAgents/:range"
      }
    ]
  },
  {
    "type": "get",
    "url": "articleCountByAnnotator",
    "title": "",
    "name": "articleCountByAnnotator",
    "group": "article",
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "article",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/articleCountByAnnotator"
      }
    ]
  },
  {
    "type": "get",
    "url": "totalArticleCount",
    "title": "",
    "name": "totalArticleCount",
    "group": "article",
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "article",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/totalArticleCount"
      }
    ]
  },
  {
    "type": "get",
    "url": "frequentDescriptors/:term",
    "title": "Request frequent descriptors for the term",
    "name": "frequentDescriptors",
    "group": "descriptors",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "term",
            "description": "<p>Infectious Agent</p>"
          },
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "promedFeedId",
            "defaultValue": "all",
            "description": "<p>The ProMED-mail regional feed to query</p>"
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "descriptors",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/frequentDescriptors/:term"
      }
    ]
  },
  {
    "type": "get",
    "url": "historicalData/:term",
    "title": "Request historical data for the term",
    "name": "historicalData",
    "group": "descriptors",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "term",
            "description": "<p>Infectious Agent</p>"
          },
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "promedFeedId",
            "defaultValue": "all",
            "description": "<p>The ProMED-mail regional feed to query</p>"
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "descriptors",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/historicalData/:term"
      }
    ]
  },
  {
    "type": "get",
    "url": "recentMentions/:term",
    "title": "Request recent mentions for the term",
    "name": "recentMentions",
    "group": "descriptors",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "term",
            "description": "<p>Infectious Agent</p>"
          },
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "to",
            "defaultValue": "now",
            "description": "<p>The last post date in ISO format</p>"
          },
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "from",
            "description": "<p>The earliest post date in ISO format</p>"
          },
          {
            "group": "Parameter",
            "type": "String",
            "optional": false,
            "field": "promedFeedId",
            "defaultValue": "all",
            "description": "<p>The ProMED-mail regional feed to query</p>"
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "descriptors",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/recentMentions/:term"
      }
    ]
  },
  {
    "type": "get",
    "url": "revision",
    "title": "",
    "name": "revision",
    "group": "revision",
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "revision",
    "sampleRequest": [
      {
        "url": "https://niam.eha.io/api/revision"
      }
    ]
  }
] });
