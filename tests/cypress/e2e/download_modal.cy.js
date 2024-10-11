describe("Download modal", () => {
  beforeEach(() => {
    cy.visit("/");
    //Importing a data to test
    cy.importing_data_flow('csv');
    //Select variables
    cy.select_flow('sequence_variable', '1');
    cy.select_flow('forecast_variable', '2');
    //Turn panel
    cy.turn_panel();
    //Train test inputs
    cy.trainin_test_inputs_flow();
    //Run flow
    cy.run_flow();
    //Start flow
    cy.start_flow();
  });

  it("'Download modal' download button", () => {
    cy.wait(240000);
    cy.get('[data-testid="close_download_modal"]')
      .should('be.visible')
      .click()
      .should('not.be.visible');
  });  

  it("'Download modal' download button", () => {
    cy.wait(240000);
    cy.get('[data-testid = "download_button"]')
      .should('be.visible')
      .click();
    const path = require('path');
    const downloads = Cypress.config('downloadsFolder');
    expect(downloads).to.be.a('string');
    const dayjs = require('dayjs');
    const currentDate = dayjs().format('YYYY-MM-DD');
    const result = path.join(downloads, `test_results_${currentDate}.json`);
    cy.readFile(result, { timeout: 15000 }).then((resultD) => {
      cy.fixture('result').then((resultF) => {
        const stringResultD = JSON.stringify(resultD);
        expect(stringResultD).to.deep.equal(JSON.stringify(resultF));
      });
    });
  });
  
});
