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

  it("'Pivot inputs' visibility - Epoch", () => {
    cy.get('[data-testid="epoch"]')
      .should('not.be.visible');
    cy.get('[data-testid="epoch"] > input')
      .should('have.value', '1');
  });

  it("'Pivot inputs' funtionality - Epoch", () => {
    cy.get('[data-testid="epoch"] button:nth-child(1)')
      .click({force: true});
    cy.get('[data-testid="epoch"] > input')
      .should('have.value', '2');
    cy.get('[data-testid="epoch"] button:nth-child(2)')
      .click({force: true});
    cy.get('[data-testid="epoch"] > input')
      .should('have.value', '1');
  });

  it("'Pivot inputs' visibility - Tests", () => {
    cy.get('[data-testid="tests"]')
      .should('not.be.visible');
    cy.get('[data-testid="tests"] > input')
      .should('have.value', '1');
  });
  
  it("'Pivot inputs' funtionality - Tests", () => {
    cy.get('[data-testid="tests"] button:nth-child(1)')
      .click({force: true});
    cy.get('[data-testid="tests"] > input')
      .should('have.value', '2');
    cy.get('[data-testid="tests"] button:nth-child(2)')
      .click({force: true});
    cy.get('[data-testid="tests"] > input')
      .should('have.value', '1');
  });
  
});
