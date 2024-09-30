describe("Decimal point", () => {
  beforeEach(() => {
    cy.visit("/");
    //Importing a data to test
    cy.importing_data_flow("csv");
  });
  it("'Decimal point'", () => {
    cy.get('[data-testid="decimal_point"]').clear().type(',');
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.compare_table_fixture('data_table', 'data_table_text_dp');
  });
})
