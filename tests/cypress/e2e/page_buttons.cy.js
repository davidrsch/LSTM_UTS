describe("Page buttons", () => {
    beforeEach(() => {
      cy.visit("/");
      //Importing a data to test
      cy.importing_data_flow('csv');
    });
    it("'Page buttons' visibility on forecast selection - showing", () => {
      cy.select_flow('forecast_variable', '2');
      cy.get('[data-testid="prevtbutton"]').should('be.visible');
      cy.get('[data-testid="nextbutton"]').should('be.visible');
    });
    it("'Page buttons' visibility on forecast selection - hidding", () => {
      cy.select_flow('forecast_variable', '2');
      cy.select_flow('sequence_variable', '1');
      cy.get('[data-testid="prevtbutton"]').should('not.be.visible');
      cy.get('[data-testid="nextbutton"]').should('not.be.visible');
    });

    it("'Page buttons' turning", () => {
      cy.select_flow('forecast_variable', '2');
      cy.get('[data-testid="prevtbutton"]')
        .should('be.visible')
        .should('be.disabled');
      cy.get('[data-testid="nextbutton"]')
        .should('be.visible')
        .should('not.be.disabled')
        .click();
      cy.get('[data-testid="prevtbutton"]')
        .should('be.visible')
        .should('not.be.disabled');
      cy.get('[data-testid="nextbutton"]')
        .should('be.visible')
        .should('be.disabled');
    });

    it("'Page buttons' run", () => {
      cy.select_flow('sequence_variable', '1');
      cy.select_flow('forecast_variable', '2');
      cy.turn_panel();
      cy.trainin_test_inputs_flow();
      cy.get('[data-testid="runbutton"')
        .should('be.visible');
    })

});
