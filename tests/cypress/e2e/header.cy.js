describe("Header", () => {
  it("'Header' csv", () => {
    cy.visit("/");
    cy.get('[data-testid="file"]').should('be.visible');
    cy.get('[data-testid="upload_file"] [type="file"]')
      .should('not.be.visible')
      .selectFile('cypress/fixtures/csv_example.csv', {force: true});
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.get('[data-testid="header"]').click({ force: true });
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.fixture('data_table_text_headless').then((expectedData) => {
      cy.getDataFromDatatable('data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
        if (currentData !== JSON.stringify(expectedData)) {
          cy.log('DataTable data does not match the expected data');
        } else {
          cy.log('Importing csv files work as expected');
        }
      });
    });
    cy.get('[data-testid="header"]').click({ force: true });
    cy.get('[data-testid="data_table"]').wait(5000);
    cy.fixture('data_table_text').then((expectedData) => {
      cy.getDataFromDatatable('data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
        if (currentData !== JSON.stringify(expectedData)) {
          cy.log('DataTable data does not match the expected data');
        } else {
          cy.log('Importing csv files work as expected');
        }
      });
    });
  });
})
