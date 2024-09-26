describe("Delimiter", () => {
  it("'Delimiter'", () => {
    cy.visit("/");
    cy.get('[data-testid="file"]').should('be.visible');
    cy.get('[data-testid="upload_file"] [type="file"]')
      .should('not.be.visible')
      .selectFile('cypress/fixtures/tsv_example.tsv', {force: true});
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.fixture('data_table_tsv').then((expectedData) => {
      cy.getDataFromDatatable('data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
    cy.get('[data-testid="delimiter"]').clear().type('\t');
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.fixture('data_table_text').then((expectedData) => {
      cy.getDataFromDatatable('data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
});
