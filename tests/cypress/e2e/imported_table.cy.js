describe("Imported table", () => {
  beforeEach(() => {
    cy.visit("/");
  });
  it("'Imported table' filter", () => {
    cy.get('[data-testid="file"]').should('be.visible');
    cy.get('[data-testid="upload_file"] [type="file"]')
      .should('not.be.visible')
      .selectFile('cypress/fixtures/csv_example.csv', {force: true});
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.get('[data-testid="dtfilter-1"]')
      .type('2023-01-02 ... 2023-01-11')
      .type('{enter}');
    cy.wait(5000);
    cy.fixture('data_table_text_fil').then((expectedData) => {
      cy.getDataFromDatatable('data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
  it("'Imported table' page", () => {
    cy.get('[data-testid="file"]').should('be.visible');
    cy.get('[data-testid="upload_file"] [type="file"]')
      .should('not.be.visible')
      .selectFile('cypress/fixtures/csv_example.csv', {force: true});
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.fixture('data_table_text').then((expectedData) => {
      cy.getDataFromDatatable('data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
    cy.get('#app-table_output-data_table #DataTables_Table_0_previous').should('have.class', 'disabled');
    cy.get('#app-table_output-data_table #DataTables_Table_0_next').should('not.have.class', 'disabled');
    cy.get('#app-table_output-data_table #DataTables_Table_0_next').click();
    cy.get('#app-table_output-data_table #DataTables_Table_0_next').should('have.class', 'disabled');
    cy.get('#app-table_output-data_table #DataTables_Table_0_previous').should('not.have.class', 'disabled');
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.fixture('data_table_csv_next').then((expectedData) => {
      cy.getDataFromDatatable('data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
});
