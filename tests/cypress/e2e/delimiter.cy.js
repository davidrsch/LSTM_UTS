describe("Delimiter", () => {
  it("'Delimiter'", () => {
    cy.visit("/");
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-upload_file')
      .should('not.be.visible')
      .selectFile('cypress/fixtures/tsv_example.tsv', {force: true});
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_tsv').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
    cy.get('#app-import_file-delimiter').clear().type('\t');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_text').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
});