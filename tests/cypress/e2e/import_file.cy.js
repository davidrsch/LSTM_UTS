describe("Import file", () => {
  beforeEach(() => {
    cy.visit("/");
  });
  it("'Import file' csv", () => {
    cy.importing_data_flow("csv");
    cy.compare_table_fixture('data_table', 'data_table_text');
  });
  
  it("'Import file' tsv", () => {
    cy.importing_data_flow("tsv");
    cy.compare_table_fixture('data_table', 'data_table_tsv');
  });
  
  it("'Import file' xls", () => {
    cy.importing_data_flow("xls");
    cy.compare_table_fixture('data_table', 'data_table_excel');
  });
  
  it("'Import file' xlsx", () => {
    cy.importing_data_flow("xlsx");
    cy.compare_table_fixture('data_table', 'data_table_excel');
  });
  
  it("'Import file' incorrect extension", () => {
    cy.importing_data_flow("png");
    cy.get('[data-testid="close_no_format"]')
      .should('be.visible')
      .click()
      .should('not.be.visible');
  });
  
});
