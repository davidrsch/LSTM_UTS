describe("Imported table", () => {
  beforeEach(() => {
    cy.visit("/");
    cy.importing_data_flow("csv");
  });
  it("'Imported table' filter", () => {
    cy.get('[data-testid="dtfilter-1"]')
      .type('2023-01-02 ... 2023-01-11')
      .type('{enter}');
    cy.wait(5000);
    cy.compare_table_fixture('data_table', 'data_table_text_fil');
  });

  it("'Imported table' page", () => {
    cy.get('[data-testid="dt-previous"]').should('have.class', 'disabled');
    cy.get('[data-testid="dt-next"]')
      .should('not.have.class', 'disabled')
      .click()
    cy.get('[data-testid="dt-next"]').should('have.class', 'disabled');
    cy.get('[data-testid="dt-previous"]').should('not.have.class', 'disabled');
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.compare_table_fixture('data_table', 'data_table_csv_next');
  });
});
