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
    "group": "C__Users_Trey_DEV_EHA_nia_monitor_public__apidocs_main_js",
    "groupTitle": "C__Users_Trey_DEV_EHA_nia_monitor_public__apidocs_main_js",
    "name": ""
  },
  {
    "type": "get",
    "url": "frequentAgents",
    "title": "Request frequent agents",
    "name": "frequentAgents",
    "group": "agent",
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "agent"
  },
  {
    "type": "get",
    "url": "recentAgents",
    "title": "Request recent Agents",
    "name": "recentAgents",
    "group": "agent",
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "agent"
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
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "agent"
  },
  {
    "type": "get",
    "url": "frequentDescriptors/:term",
    "title": "{{pathFor \"frequentDescriptors\"}} Request frequent descriptors for the term",
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
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "descriptors"
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
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "descriptors"
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
          }
        ]
      }
    },
    "version": "0.0.0",
    "filename": "./imports/startup/server/index.coffee",
    "groupTitle": "descriptors"
  }
] });
