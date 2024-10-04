describe("Run modal", () => {
    beforeEach(() => {
      cy.visit("/");
      //Importing a data to test
      cy.importing_data_flow('csv');
      //Select variables
      cy.select_flow('sequence_variable', '1');
      cy.select_flow('forecast_variable', '2');
      //Turn panel
      cy.turn_panel();
      cy.trainin_test_inputs_flow();
      cy.run_flow();
    });

    it("'Run modal' visibility", () => {
      cy.get('[data-testid="close_run_modal"]')
      .should('be.visible')
      .click()
      .should('not.be.visible');
    });

    it("'Run modal' table", () => {
      cy.wait(5000);
      cy.compare_table_fixture('iterations_table', 'iterations');
    });

});
