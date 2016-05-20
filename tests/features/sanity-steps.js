module.exports = function () {
 'use strict';

 this.Given(/^I am on the site$/, function () {
    browser.url('http://localhost:3000');
  });

  this.Then(/^I should see the header$/, function () {
    let el = '#header';
    expect(browser.getText(el)).toEqual('Novel Infectious Agent Monitoring');
  });
};
