import 'cypress-file-upload';
import $ from 'jquery';
import _ from 'lodash';

Cypress.Commands.add('getDataFromDatatable', (datatable_testid) => {
  cy.get(`[data-testid="${datatable_testid}"]`).then(($datatable) => {
    const data = [];

    // Extract header data (excluding the first `th`)
    $datatable.find('thead tr:first-child').each((index, row) => {
      const rowData = [];
      $(row).find('th').each((index, cell) => {
        rowData.push($(cell).text());
      });
      data.push(rowData);
    });

    // Extract tbody data
    $datatable.find('tbody tr').each((index, row) => {
      const rowData = [];
      $(row).find('td').each((index, cell) => {
        rowData.push($(cell).text());
      });
      data.push(rowData);
    });

    return JSON.stringify(data);
  });
});

Cypress.Commands.add('compare_table_fixture', (table, fixture) => {
  cy.fixture(fixture).then((expectedData) => {
    cy.getDataFromDatatable(table).then((currentData) => {
      expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      if (currentData !== JSON.stringify(expectedData)) {
        cy.log('DataTable data does not match the expected data');
      } else {
        cy.log('DataTable data match the expected data');
      }
    });
  });
})

Cypress.Commands.add('importing_data_flow', (test_data) => {
  cy.get('[data-testid="file"]').should('be.visible');
  cy.get('[data-testid="upload_file"] [type="file"]')
      .should('not.be.visible')
      .selectFile(`cypress/fixtures/${test_data}_example.${test_data}`, {force: true});
  cy.get('[data-testid="data_table"]').wait(5000);
});

Cypress.Commands.add('select_variable_flow', () => {
  cy.get('#app-select_variables-sequence_variable').should('be.visible');
  cy.get('#app-select_variables-sequence_variable').click();
  cy.get('#app-select_variables-sequence_variable-list0').click();
  cy.get('#app-select_variables-forecast_variable').should('be.visible');
  cy.get('#app-select_variables-forecast_variable').click();
  cy.get('#app-select_variables-forecast_variable-list1').click();
});

Cypress.Commands.add('turn_panel', () => {
  cy.get('#app-page_buttons-nextbutton').should('be.visible');
  cy.get('#app-page_buttons-nextbutton').click();
});
