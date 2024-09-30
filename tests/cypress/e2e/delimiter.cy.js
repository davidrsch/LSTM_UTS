describe("Delimiter", () => {
  beforeEach(() => {
    cy.visit("/");
    //Importing a data to test
    cy.importing_data_flow("tsv");
  });
  it("'Delimiter'", () => {
    cy.get('[data-testid="delimiter"]').clear().type('\t');
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.compare_table_fixture('data_table', 'data_table_text');
  });
});
