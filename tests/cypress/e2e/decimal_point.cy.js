describe("Decimal point", () => {
  it("'Decimal point'", () => {
    cy.visit("/");
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-file').attachFile('csv_example.csv');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_text').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
    cy.get('#app-import_file-decimal_point').clear().type(',');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_text_dp').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
})