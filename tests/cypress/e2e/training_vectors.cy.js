describe("Pivot inputs", () => {
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
    
    it("'Pivot inputs' visibility - Horizontal", () => {
      cy.get('[data-testid="horizon"]')
        .should('not.be.visible');
      cy.get('[data-testid="horizon"] > input')
        .should('have.value', '1');
    });
  
    it("'Pivot inputs' funtionality - Horizon", () => {
      cy.get('[data-testid="horizon"] button:nth-child(1)')
        .click({force: true});
      cy.get('[data-testid="horizon"] > input')
        .should('have.value', '2');
      cy.get('[data-testid="horizon"] button:nth-child(2)')
        .click({force: true});
      cy.get('[data-testid="horizon"] > input')
        .should('have.value', '1');
    });
  
    it("'Pivot inputs' visibility - Input amount", () => {
      cy.get('[data-testid="inp_amount"]')
        .should('not.be.visible')
        .should('have.text', '');
    });
  
    it("'Pivot inputs' funtionality - Input amount", () => {
      cy.get('[data-testid="inp_amount"]')
        .type('ab1,+-2', {force: true})
        .should('have.value', '1,2');
    });
    
});
