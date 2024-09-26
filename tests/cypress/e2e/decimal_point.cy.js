describe("Decimal point", () => {
  it("'Decimal point'", () => {
    cy.visit("/");
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
    cy.get('[data-testid="decimal_point"]').clear().type(',');
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.fixture('data_table_text_dp').then((expectedData) => {
      cy.getDataFromDatatable('data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
})
