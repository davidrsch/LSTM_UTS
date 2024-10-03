describe("LSTM", () => {
    beforeEach(() => {
      cy.visit("/");
      //Importing a data to test
      cy.importing_data_flow('csv');
      //Select variables
      cy.select_flow('sequence_variable', '1');
      cy.select_flow('forecast_variable', '2');
      //Turn panel
      cy.turn_panel();
      
    });
    
    it("'LSTM' visibility", () => {
      cy.get('[data-testid="lstm"]')
        .should('not.be.visible')
        .should('have.text', '');
    });
  
    it("'LSTM' functionality", () => {
      cy.get('[data-testid="lstm"]')
        .type('ab16,+-32', {force: true})
        .should('have.value', '16,32');
    });
    
});
