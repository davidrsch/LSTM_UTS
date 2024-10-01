describe("Select variables", () => {
  beforeEach(() => {
    cy.visit("/");
    //Importing a data to test
    cy.importing_data_flow("csv");
  });

  it("'Select variables' sequence visibility", () => {
    cy.get('[data-testid="sequence_variable"]').click();
    cy.get('[data-testid="sequence_variable-callout"]')
      .should('be.visible')
      .find('[data-index="0"]')
      .should('be.visible')
      .should("have.text", "");
    cy.get('[data-testid="sequence_variable-callout"]')
      .should('be.visible')
      .find('[data-index="1"]')
      .should('be.visible')
      .should("have.text", "Date");
    cy.get('[data-testid="sequence_variable-callout"]')
      .should('be.visible')
      .find('[data-index="2"]')
      .should('be.visible')
      .should("have.text", "Value1");
    cy.get('[data-testid="sequence_variable-callout"]')
      .should('be.visible')
      .find('[data-index="3"]')
      .should('be.visible')
      .should("have.text", "Value2");
  });

  it("'Select variables' sequence selecting", () => {
    cy.select_flow('sequence_variable', '0');
    cy.get('[data-testid="sequence_variable"]')
      .should("have.text", "");
    cy.select_flow('sequence_variable', '1');
    cy.get('[data-testid="sequence_variable"]')
      .should("have.text", "Date");
    cy.select_flow('sequence_variable', '2');
    cy.get('[data-testid="sequence_variable"]')
      .should("have.text", "Value1");
    cy.select_flow('sequence_variable', '3');
    cy.get('[data-testid="sequence_variable"]')
        .should("have.text", "Value2");
  });

  it("'Select variables' forecast", () => {
    cy.get('[data-testid="forecast_variable"]').click();
    cy.get('[data-testid="forecast_variable-callout"]')
      .should('be.visible')
      .find('[data-index="0"]')
      .should('be.visible')
      .should("have.text", "");
    cy.get('[data-testid="forecast_variable-callout"]')
      .should('be.visible')
      .find('[data-index="1"]')
      .should('be.visible')
      .should("have.text", "Date");
    cy.get('[data-testid="forecast_variable-callout"]')
      .should('be.visible')
      .find('[data-index="2"]')
      .should('be.visible')
      .should("have.text", "Value1");
    cy.get('[data-testid="forecast_variable-callout"]')
      .should('be.visible')
      .find('[data-index="3"]')
      .should('be.visible')
      .should("have.text", "Value2");
  });

  it("'Select variables' forecast selecting", () => {
    cy.select_flow('forecast_variable', '0');
    cy.get('[data-testid="forecast_variable"]')
      .should("have.text", "");
    cy.select_flow('forecast_variable', '1');
    cy.get('[data-testid="forecast_variable"]')
      .should("have.text", "Date");
    cy.select_flow('forecast_variable', '2');
    cy.get('[data-testid="forecast_variable"]')
      .should("have.text", "Value1");
    cy.select_flow('forecast_variable', '3');
    cy.get('[data-testid="forecast_variable"]')
        .should("have.text", "Value2");
  });

  it("'Select variables' sequences over forecast - reseting", () => {
    cy.select_flow('forecast_variable', '2');
    cy.select_flow('sequence_variable', '1');
    cy.get('[data-testid="forecast_variable"]')
      .should("have.text", "");
  });

  it("'Select variables' sequences over forecast - disabling", () => {
    cy.select_flow('sequence_variable', '1');
    cy.get('[data-testid="forecast_variable"]').click();
    cy.get('[data-testid="forecast_variable-callout"]')
      .should('be.visible')
      .find('[data-index="1"]')
      .should('be.disabled');
  });
});