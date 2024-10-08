describe("Training and Testing", () => {
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

  it("'Training and Testing' Epoch visibility", () => {
    cy.get('[data-testid="epoch"]')
      .should('not.be.visible');
    cy.get('[data-testid="epoch"] > input')
      .should('have.value', '1');
  });

  it("'Training and Testing' Epoch functionality", () => {
    cy.get('[data-testid="epoch"] button:nth-child(1)')
      .click({force: true});
    cy.get('[data-testid="epoch"] > input')
      .should('have.value', '2');
    cy.get('[data-testid="epoch"] button:nth-child(2)')
      .click({force: true});
    cy.get('[data-testid="epoch"] > input')
      .should('have.value', '1');
  });

  it("'Training and Testing' Tests visibility", () => {
    cy.get('[data-testid="tests"]')
      .should('not.be.visible');
    cy.get('[data-testid="tests"] > input')
      .should('have.value', '1');
  });
  
  it("'Training and Testing' Tests functionality", () => {
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
