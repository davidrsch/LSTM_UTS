describe("Header", () => {
  beforeEach(() => {
    cy.visit("/");
    //Importing a data to test
    cy.importing_data_flow("csv");
  });
  it("'Header'", () => {
    cy.get('[data-testid="header"]').click({ force: true });
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.compare_table_fixture('data_table', 'data_table_text_headless');
    cy.get('[data-testid="header"]').click({ force: true });
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.compare_table_fixture('data_table', 'data_table_text');
  });
})
