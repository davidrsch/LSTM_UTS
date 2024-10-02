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
    
    it("'Pivot inputs' Transformations: visibility", () => {
      cy.get('[data-testid="transformation"]')
        .should('not.be.visible')
        .click({force: true});
      cy.get('[data-testid="transformation-callout"]')
        .should('be.visible')
        .find('[data-index="0"]')
        .siblings('label')
        .should('be.visible')
        .should('have.text', "Original");
      cy.get('[data-testid="transformation-callout"]')
        .should('be.visible')
        .find('[data-index="1"]')
        .siblings('label')
        .should('be.visible')
        .should('have.text', "First");
      cy.get('[data-testid="transformation-callout"]')
        .should('be.visible')
        .find('[data-index="2"]')
        .siblings('label')
        .should('be.visible')
        .should('have.text', "Second");
    });
  
    it("'Pivot inputs' Transformations: funtionality 1", () => {
      cy.select_flow('transformation', 0);
      cy.get('[data-testid="transformation"]')
        .should("have.text", "Original");
    });

    it("'Pivot inputs' Transformations: funtionality 2", () => {
        cy.select_flow('transformation', [0, 1]);
        cy.get('[data-testid="transformation"]')
          .should("have.text", "Original, First");
    });
  
    it("'Pivot inputs' Transformations: funtionality 3", () => {
        cy.select_flow('transformation', [0, 1, 2]);
        cy.get('[data-testid="transformation"]')
          .should("have.text", "Original, First, Second");
    });

    it("'Pivot inputs' Scale: visibility", () => {
      cy.get('[data-testid="scale"]')
        .should('not.be.visible')
        .click({force: true});
      cy.get('[data-testid="scale-callout"]')
        .should('be.visible')
        .find('[data-index="0"]')
        .siblings('label')
        .should('be.visible')
        .should('have.text', "Exact");
      cy.get('[data-testid="scale-callout"]')
        .should('be.visible')
        .find('[data-index="1"]')
        .siblings('label')
        .should('be.visible')
        .should('have.text', "0 to 1");
      cy.get('[data-testid="scale-callout"]')
        .should('be.visible')
        .find('[data-index="2"]')
        .siblings('label')
        .should('be.visible')
        .should('have.text', "-1 to 1");
    });
  
    it("'Pivot inputs' Scale: funtionality 1", () => {
      cy.select_flow('scale', 0);
      cy.get('[data-testid="scale"]')
        .should("have.text", "Exact");
    });

    it("'Pivot inputs' Scale: funtionality 2", () => {
        cy.select_flow('scale', [0 , 1]);
        cy.get('[data-testid="scale"]')
          .should("have.text", "Exact, 0 to 1");
    });
    
    it("'Pivot inputs' Scale: funtionality 3", () => {
        cy.select_flow('scale', [0, 1, 2]);
        cy.get('[data-testid="scale"]')
          .should("have.text", "Exact, 0 to 1, -1 to 1");
    });

});
