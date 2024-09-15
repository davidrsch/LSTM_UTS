describe("Imported table", () => {
  beforeEach(() => {
    cy.visit("/");
  });
  it("'Imported table' filter", () => {
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-file').attachFile('csv_example.csv');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.get('#app-table_output-data_table thead tr:nth-child(2) td:nth-child(2) input[type="search"]').type('2023-01-02 ... 2023-01-11').type('{enter}');
    cy.wait(5000);
    cy.fixture('data_table_text_fil').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
  it("'Imported table' page", () => {
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-file').attachFile('xlsx_example.xlsx');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_excel').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
    cy.get('#app-table_output-data_table #DataTables_Table_0_previous').should('have.class', 'disabled');
    cy.get('#app-table_output-data_table #DataTables_Table_0_next').should('not.have.class', 'disabled');
    cy.get('#app-table_output-data_table #DataTables_Table_0_next').click();
    cy.get('#app-table_output-data_table #DataTables_Table_0_next').should('have.class', 'disabled');
    cy.get('#app-table_output-data_table #DataTables_Table_0_previous').should('not.have.class', 'disabled');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_excel_next').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
});
