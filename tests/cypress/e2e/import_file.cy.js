describe("Import file", () => {
  beforeEach(() => {
    cy.visit("/");
  });
  it("'Import file' csv", () => {
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-file').selectFile('cypress/fixtures/csv_example.csv');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_text').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
  
  it("'Import file' tsv", () => {
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-file').selectFile('cypress/fixtures/tsv_example.tsv');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_tsv').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
  
  it("'Import file' xls", () => {
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-file').selectFile('cypress/fixtures/xls_example.xls');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_excel.json').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
  
  it("'Import file' xlsx", () => {
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-file').selectFile('cypress/fixtures/xlsx_example.xlsx');
    cy.get('#app-table_output-data_table').wait(5000);
    cy.fixture('data_table_excel.json').then((expectedData) => {
      cy.getDataFromDatatable('app-table_output-data_table').then((currentData) => {
        expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      });
    });
  });
  
  it("'Import file' incorrect extension", () => {
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-file').selectFile('cypress/fixtures/LSTM_UTS-ss.png');
    cy.get("#app-no_format_modal-make_modal-hideModal").should('be.visible');
    cy.get("#app-no_format_modal-make_modal-hideModal").click();
    cy.get("#app-no_format_modal-make_modal-hideModal").should('not.be.visible');
  });
  
});
